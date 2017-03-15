/**
* This module provides several variables. Paired with static if's these
* variables can be used for $(LINK2 https://dlang.org/spec/version.html, conditional compilation)
*
* example:
* ---
* static if(os == "Windows") {
*     //code for windows
* }
* else {
*     //generic code	
* }
* ---
*/

module caLib_util.build;



/**
* An enum string representing the target operating system.
* $(BR)possible values:
* $(UL
*     $(LI "Windows")
*     $(LI "Linux")
*     $(LI "OSX")
* )
*/
version(Windows)
{
	enum string os = "Windows";
}
version(linux)
{
	enum string os = "Linux";
}
version(OSX)
{
	enum string os = "OSX";
}

static assert(is(typeof(os)), "This os is not supported. Windows, Linux"
	~ " and Mac os are the only os:es currently supported");



/**
* An enum string representing the target architecture.
* $(BR)possible values:
* $(UL
*     $(LI "x86" (32-bit))
*     $(LI "x86_64" (64-bit))
*     $(LI "ARM" (32-bit))
* )
*/
version(X86)
{
	enum string arch = "x86";
}
version(X86_64)
{
	enum string arch = "x86_64";
}
version(ARM)
{
	enum string arch = "ARM";
}

static assert(is(typeof(arch)), "This computer architecture is not supported."
	~ "x86, x86_64 and ARM are the only architectures currently supported");



pragma(msg, "----\ncompiling with settings:");
pragma(msg, "    os: " ~ os);
pragma(msg, "    architecture: " ~ arch);
pragma(msg, "----");