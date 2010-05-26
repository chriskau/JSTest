#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


static JSGlobalContextRef context = 0;

static char* createStringWithContentsOfFile(const char* fileName);

int main (int argc, const char * argv[])
{
    const char *scriptPath = "testapi.js";
    if (argc > 1) {
        scriptPath = argv[1];
    }

    context = JSGlobalContextCreate(NULL);
    
    // calling an anonymous function
    JSStringRef script = JSStringCreateWithUTF8CString("return 'hello world'");
    JSObjectRef fn = JSObjectMakeFunction(context, NULL, 0, NULL, script, NULL, 1, NULL);
    JSValueRef result = JSObjectCallAsFunction(context, fn, NULL, 0, NULL, NULL);
    JSStringRef resultIString = JSValueToStringCopy(context, result, NULL);
    CFStringRef resultCF = JSStringCopyCFString(kCFAllocatorDefault, resultIString);
    CFShow(resultCF);
    CFRelease(resultCF);
    JSStringRelease(resultIString);
    
    
    char* scriptUTF8 = createStringWithContentsOfFile(scriptPath);
    if (!scriptUTF8) {
        printf("FAIL: Test script could not be loaded.\n");
    }
    else {
        JSStringRef script = JSStringCreateWithUTF8CString(scriptUTF8);
        JSValueRef exception;
        JSValueRef result = JSEvaluateScript(context, script, NULL, NULL, 1, &exception);
        
        if (JSValueIsUndefined(context, result)) {
            printf("PASS: Test script executed successfully.\n");
                    
            // try calling function defined in test.js
            JSStringRef functionName = JSStringCreateWithUTF8CString("sayHello");
            JSObjectRef fn = JSObjectMakeFunction(context, functionName, 0, NULL, script, NULL, 1, NULL);
            JSValueRef result = JSObjectCallAsFunction(context, fn, NULL, 0, NULL, NULL);
            JSStringRef resultIString = JSValueToStringCopy(context, result, NULL);
            CFStringRef resultCF = JSStringCopyCFString(kCFAllocatorDefault, resultIString);
            CFShow(resultCF);
            CFRelease(resultCF);
            JSStringRelease(resultIString);
        }
        else {
            printf("FAIL: Test script returned unexpected value:\n");
            JSStringRef exceptionIString = JSValueToStringCopy(context, exception, NULL);
            CFStringRef exceptionCF = JSStringCopyCFString(kCFAllocatorDefault, exceptionIString);
            CFShow(exceptionCF);
            CFRelease(exceptionCF);
            JSStringRelease(exceptionIString);
        }

        JSStringRelease(script);
    }
    
    free(scriptUTF8);

    JSGlobalContextRelease(context);
    
    return 0;
}


static char* createStringWithContentsOfFile(const char* fileName)
{
    char* buffer;
    
    size_t buffer_size = 0;
    size_t buffer_capacity = 1024;
    buffer = (char*)malloc(buffer_capacity);
    
    FILE* f = fopen(fileName, "r");
    if (!f) {
        fprintf(stderr, "Could not open file: %s\n", fileName);
        return 0;
    }
    
    while (!feof(f) && !ferror(f)) {
        buffer_size += fread(buffer + buffer_size, 1, buffer_capacity - buffer_size, f);
        if (buffer_size == buffer_capacity) { // guarantees space for trailing '\0'
            buffer_capacity *= 2;
            buffer = (char*)realloc(buffer, buffer_capacity);
        }
        
    }
    fclose(f);
    buffer[buffer_size] = '\0';
    
    return buffer;
}