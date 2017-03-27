/**
* This module defines the notion of a $(RENDERER). A $(RENDERER) is responsible
* for "rendering" the $(I ca's) $(LATTICE) in a way that humans can appriciate.
* While a $(RENDERER) is not "mathematicly" part of a $(I cellular automaton), it
* is here for obvious reasons.
*
* This module provides templates for testing whether a given object is a $(RENDERER),
* and what kind of $(RENDERER) it is.
*
* $(CALIB_ABSTRACT_DESC)
*/

module caLib_abstract.renderer;

/**
* Returns `true` if T is a $(B Renderer) defined as having the primitives:
* `void render()` $(BR)
* `void screendshot(string path)`
* `void startRecording(string path)`
* `void stopRecording()`
*
* A $(B Renderer) is the most basic form of a $(RENDERER).
*/
enum isRenderer(T) =
	is(typeof(T.init.render()) : void) &&
	is(typeof(T.init.screenshot("")) : void) &&
	is(typeof(T.init.startRecording("", uint.init)) : void) &&
	is(typeof(T.init.stopRecording()) : void);

unittest
{
	static assert( isRenderer!Renderer);
	static assert(!isRenderer!string);
}



/// Example of a $(B Renderer)
struct Renderer
{
	void render() {}

	void screenshot(string path) {}
	
	void startRecording(string path, uint framerate) {}
	void stopRecording() {}
}

///
unittest
{
	static assert( isRenderer!Renderer);
	static assert(!isRenderer!string);
}