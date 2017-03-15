/**
* This module provides classes used to display graphics.
* It builds uppon $(LINK2 https://www.libsdl.org/download-2.0.php, SDL2)
* and if you'd rather use sdl it's functions can be called directly by
* imporrting like this: `import caLit_util.graphics.derelict.sdl2.sdl`
*/

module caLib_util.graphics;

import std.stdio : writeln;
import std.file : dirName, thisExePath;
import std.exception : enforce;
import std.conv : to;
import caLib_util.build : arch, os;

public import derelict.sdl2.sdl;



shared static this()
{
        DerelictSDL2.load();
}



/**
* A class representing a window
* 
* It wrapps a $(B SDL_Window) and $(B SDL_Renderer) wich can both be freely retrived
* and manipulated
*/
class Window
{

private:

    uint screenWidth;
    uint screenHeight;

    SDL_Window* window;
    SDL_Renderer* renderer;

public:

    ///
    this(int screenWidth, int screenHeight)
    {
        this(screenWidth, screenHeight, "GCaL");
    }

    ///
    this(uint screenWidth, uint screenHeight, string title)
    in { assert(title !is null); }
    body
    {
        
        this.screenWidth = screenWidth;
        this.screenHeight = screenHeight;

        SDL_Window* window;

        int err = SDL_Init(SDL_INIT_EVERYTHING);

        assert(err >= 0, "SDL could not initialize! SDL_Error: "
            ~ to!string(SDL_GetError()) ~ "\n");
        
        window = SDL_CreateWindow(cast(const char*)title,
            SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
            screenWidth, screenHeight, SDL_WINDOW_SHOWN);

        assert(window !is(null), "Window could not be created! SDL_Error: "
            ~ to!string(SDL_GetError()) ~ "\n");

        renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    }

    ~this()
    {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
    }

    /// Returns the width of the screen in pixels
    int getWidth()
    {
        return screenWidth;
    }

    /// Returns the height of the screen in pixels
    int getHeight()
    {
        return screenHeight;
    }

    /// Returns a reference to the $(B SDL_Window) wrapped in this class
    SDL_Window* getWindow()
    {
        return window;
    }

    /// Returns a reference to the $(B SDL_Renderer) wrapped in this class
    SDL_Renderer* getRenderer()
    {
        return renderer;
    }
}



/**
* A class representing a texture. A texture contains the pixeldata that can
* be rendered to its associated $(B Window).
* 
* It wrapps a $(B SDL_Texture) wich can be freely retrived and manipulated
*/
class Texture
{

private:

    uint textureWidth;
    uint textureHeight;

    SDL_Texture* texture;

    int pitch;

    immutable bpp = 4;
    immutable depth = 8*bpp;
    immutable pixelFormat = SDL_PIXELFORMAT_ARGB8888;

public:

    ///
    this(Window window, int textureWidth, int textureHeight)
    in
    { assert(window !is null); }
    body
    {
        DerelictSDL2.load();

        this.textureWidth = textureWidth;
        this.textureHeight = textureHeight;
        pitch = textureWidth * bpp;
        depth = 8*bpp;

        texture = SDL_CreateTexture(window.getRenderer(),
                                    pixelFormat,
                                    SDL_TEXTUREACCESS_STREAMING,
                                    textureWidth, textureHeight);
    }

    ~this()
    {
        SDL_DestroyTexture(texture);
    }

    /**
    * Lock the texture to manipulate its pixeldata
    *
    * Locks the thexture meaning that the texture can't be used for anything
    * untill its $(CU unlock) method is called
    *
    * A pointer is returned. It points to the pixeldata wich can be manipulated.
    * The length of the pixeldata is the textures width*height. The value for
    * a pixel at location x, y can be obtained by getting the element at index
    * y * width + x
    *
    * Examples:
    * ----
    * auto window = new Window(800, 400, "myTestWindow"); //create a window
    * auto texture = new Texture(window, 300, 100); //create a texture
    * uint* pixels = texture.lock() //lock the texture and get the pixeldata pointer
    * pixels[10 * texture.getWidth() + 20] = 0x00FF0000; // make the pixel at position 20, 10 red
    * texture.lock() //now were done manipulating the pixels, unlock the texture
    *
    * // render the texture to the window
    * SDL_RenderCopy(window.getRenderer(), texture.getTexture(), SDL_Rect(0,0,300,100), SDL_Rect(0,0,800,400));
    * SDL_RenderPresent(window.getRenderer());
    * ----
    *
    * Returns:
    *     A pointer to the pixeldata, 
    */
    uint* lock()
    {
        void* pixelsptr;
        int[] pitch = [pitch];
        SDL_LockTexture(texture, null, &pixelsptr, pitch.ptr);
        uint* pixels = cast(uint*)(pixelsptr);
        return pixels;
    }

    /// Unlocks the texture
    void unlock()
    {
        SDL_UnlockTexture(texture);
    }

    /// Returns the texture's width in pixels
    uint getWidth()
    {
        return textureWidth;
    }

    /// Return the texture's height in pixels
    uint getHeight()
    {
        return textureHeight;
    }

    /**
    * Returns the pixel format
    *
    * The pixel format is a SDL_PIXELFORMAT and the default is
    * SDL_PIXELFORMAT_ARGB8888
    */
    int getPixelFormat()
    {
        return pixelFormat;
    }

    /// Returns the pixels depth
    int getDepth()
    {
        return depth;
    }

    /// Returns the pitch
    int getPitch()
    {
        return pitch;
    }

    /// Retuens the internal $(B SDL_Texture)
    SDL_Texture* getTexture()
    {
        return texture;
    }
}



/// Creates a $(B SDL_Surface) from a $(B Texture).
SDL_Surface* createRGBSurfaceFromTexture(Texture texture)
{
    uint* pixels = texture.lock();
    scope(exit) texture.unlock();
    return SDL_CreateRGBSurfaceFrom(pixels, texture.getWidth(),
        texture.getHeight(), texture.getDepth(), texture.getPitch(),
        0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000);
}



/// Saves a $(B Texture) as a bitmap picture
void saveTextureAsBmp(Texture texture, string path)
{
    SDL_Surface* sshot = createRGBSurfaceFromTexture(texture);
    scope(exit) SDL_FreeSurface(sshot);

    int err = SDL_SaveBMP(sshot, cast(const char*)(path));

    enforce(err != -1, "Could not save image \"" ~ path ~ "\" SDL_Error: "
        ~ to!string(SDL_GetError()));
}