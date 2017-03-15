module caLib.renderers.TwoDimBasicRenderer;

import caLib_abstract.lattice : isLattice, isAnyLattice, isBoundedLattice;
import caLib_abstract.palette : isColorPalette, isAnyColorPalette;
import std.exception : enforce;
import std.algorithm : canFind;
import std.algorithm.comparison : max;
import std.traits : CommonType;
import caLib_util.image : Image;
import caLib_util.video : Video;
import caLib_util.structs : Rect, Color;
import caLib_util.graphics;

public import caLib_util.graphics : Window;



template create_TwoDimBasicRenderer(Ct, Lt, Pt)
if(isLattice!(Lt, Ct, 2) && isColorPalette!(Pt, Ct))
{
    TwoDimBasicRenderer!(Ct, Lt, Pt)*
    create_TwoDimBasicRenderer(Lt* lattice, Pt* palette, Window window)
    {
        return new TwoDimBasicRenderer!(Ct, Lt, Pt)(lattice, palette, window);
    }
}




auto create_TwoDimBasicRenderer(Lt, Pt)(Lt* lattice, Pt* palette, Window window)
if(isAnyLattice!Lt && isAnyColorPalette!Pt && Lt.Dimension == 2)
{
    alias Ct = CommonType!(Lt.CellStateType, Pt.CellStateType);
    static assert(!is(Ct == void));

    return new TwoDimBasicRenderer!(Ct, Lt, Pt)(lattice, palette, window);
}



struct TwoDimBasicRenderer(Ct, Lt, Pt)
if(isColorPalette!(Pt, Ct) && isLattice!(Lt, Ct, 2))
{

private:

    Lt* lattice;

    Pt* palette;

    Rect v;

    Window window;
    Texture texture;

    bool recording;
    string videoPath;
    Video video;

public:

    this(Lt* lattice, Pt* palette, Window window)
    {
        this.lattice = lattice;
        this.palette = palette;

        this.window = window;

        v = setupViewPort(window, lattice);

        texture = new Texture(window, v.w, v.h);

        recording = false;
        videoPath = null;
        video = null;
    }

    void render()
    {
        {
            uint* pixels = texture.lock();
            scope(exit) texture.unlock();

            for(int row=v.y; row<v.y + v.h; row++)
            {
                for(int col=v.x; col<v.x + v.w; col++)
                {
                    // TODO if the lattice's get method
                    //have a "bounded-assumeInBounds" behaviour, use it
                    pixels[(row-v.y) * texture.getWidth() + (col-v.x)] =
                        palette.getDisplayValue(lattice.get(col, row));
                }
            }

            if(recording)
                video.addFrame(Image.fromColorValues(pixels, v.w, v.h));
        }

        SDL_Rect srect = {0, 0, texture.getWidth(), texture.getHeight()};
        SDL_Rect drect = {0, 0, window.getWidth(), window.getHeight()};
        SDL_RenderCopy(window.getRenderer(), texture.getTexture(), &srect, &drect);

        SDL_RenderPresent(window.getRenderer());
    }

    void screenshot(string path)
    in
    { assert(path !is(null)); }
    body
    {
        Image image = Image.fromColorValues(texture.lock(), v.w, v.h);
        image.saveToFile(path);

        scope(exit) texture.unlock();
    }

    void startRecording(string path, uint framerate)
    {
        if(recording)
            stopRecording();

        recording = true;
        video = new Video(path, framerate);
        videoPath = path;
    }
    
    void stopRecording()
    {
        video.saveToFile();
        recording = false;
        video = null;
        videoPath = null;
    }

    void moveViewport(int xDir, int yDir){}
    void zoom(int factor){}

private:

    static Rect setupViewPort(Window window, Lt* lattice)
    {
        Rect viewport;

        int cellSize = (window.getWidth() + window.getHeight()) / 2 / 10;

        viewport.x = window.getWidth()/cellSize/2 * -1;
        viewport.y = window.getHeight()/cellSize/2 * -1;
        viewport.w = window.getWidth()/cellSize;
        viewport.h = window.getHeight()/cellSize;

        // if the lattice is bounded, set the viewport's size accordingly
        static if(isBoundedLattice!(Lt, Ct, 2))
        {
            int xLength = lattice.getLatticeBounds[0];
            int yLength = lattice.getLatticeBounds[1];
            int length = max(xLength, yLength);

            viewport.x = - (length - xLength) / 2;
            viewport.y = - (length - yLength) / 2;
            viewport.w = length;
            viewport.h = length;
        }

        return viewport;
    }
}



version(unittest)
{
    import caLib_abstract.renderer : isRenderer;
    import caLib_abstract.lattice : Lattice;
    import caLib_abstract.palette : Palette;
}



unittest
{
    alias Ct = string;
    assert(isRenderer!(TwoDimBasicRenderer!(Ct, Lattice!(Ct, 2), Palette!(Ct, Color))));
}