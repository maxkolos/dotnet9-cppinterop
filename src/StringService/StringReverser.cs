using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace StringService
{
    // Service for string reversion. 
    public static class StringReverser
    {
        private static IntPtr _libHandle;
        private delegate void ReverseStringDelegate(IntPtr char16_array, int length);
        private static ReverseStringDelegate _reverseFunc;

        static StringReverser()
        {
            var libPath = Path.Combine(AppContext.BaseDirectory, "libreverse_string.so");
            _libHandle = NativeLibrary.Load(libPath);

            if (!NativeLibrary.TryGetExport(_libHandle, "reverse_char16_array", out IntPtr reverseFuncPtr))
            {
                throw new EntryPointNotFoundException("Function 'reverse_char16_array' not found in the library");
            }

            _reverseFunc = Marshal.GetDelegateForFunctionPointer<ReverseStringDelegate>(reverseFuncPtr);

            // TODO: Consider unloading the library in AppDomain.CurrentDomain.ProcessExit. For a lightweight 
            // library with straightforward usage, letting the static class be cleaned up automatically is sufficient.
        }

        // Returns a reversed `input`.
        public static string? Reverse(string input)
        {
            if (input == null) return null;
            var chars = input.ToCharArray();
            
            unsafe
            {
                fixed (char* pChars = chars)
                {
                    _reverseFunc((IntPtr)pChars, chars.Length);
                }
            }

            return new string(chars);
        }
    }
}