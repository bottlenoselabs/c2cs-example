using System.Runtime.InteropServices;

namespace HelloWorld;

using static helloworld;
using static helloworld.Runtime;

internal static class Program
{
    private static void Main()
    {
        Setup(); // Load native library now, will throw if can't load native library or can't find native function
        
        hw_hello_world();
        
        var cStringHelloWorld = (CString)"Hello world from C#!";
        hw_print_string(cStringHelloWorld);
        Marshal.FreeHGlobal(cStringHelloWorld);
    }
}