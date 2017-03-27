module caLib.renderers.TwoDimBasicRenderer;

import caLib_abstract.lattice : isBoundedLattice, isAnyBoundedLattice;
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
if(isBoundedLattice!(Lt, Ct, 2) && isColorPalette!(Pt, Ct))
{
    TwoDimBasicRenderer!(Ct, Lt, Pt)*
    create_TwoDimBasicRenderer(Lt* lattice, Pt* palette, Window window)
    {
        return new TwoDimBasicRenderer!(Ct, Lt, Pt)(lattice, palette, window);
    }
}




auto create_TwoDimBasicRenderer(Lt, Pt)(Lt* lattice, Pt* palette, Window window)
if(isAnyBoundedLattice!Lt && isAnyColorPalette!Pt && Lt.Dimension == 2)
{
    alias Ct = CommonType!(Lt.CellStateType, Pt.CellStateType);
    static assert(!is(Ct == void));

    return new TwoDimBasicRenderer!(Ct, Lt, Pt)(lattice, palette, window);
}



struct TwoDimBasicRenderer(Ct, Lt, Pt)
if(isColorPalette!(Pt, Ct) && isBoundedLattice!(Lt, Ct, 2))
{

private:

    Lt* lattice;

    Pt* palette;

    Window window;
    Texture texture;
    immutable SDL_Rect sRect;
    immutable SDL_Rect dRect;

    bool recording;
    string videoPath;
    Video video;

public:

    this(Lt* lattice, Pt* palette, Window window)
    {
        this.lattice = lattice;
        this.palette = palette;

        this.window = window;

        texture = new Texture(window, lattice.getLatticeBounds()[0], lattice.getLatticeBounds()[1]);
        sRect = SDL_Rect(0, 0, texture.getWidth(), texture.getHeight());
        dRect = setupDRect();

        recording = false;
        videoPath = null;
        video = null;
    }

    void render()
    {
        {
            uint* pixels = texture.lock();
            scope(exit) texture.unlock();

            for(int row=0; row<sRect.h; row++)
            {
                for(int col=0; col<sRect.w; col++)
                {
                    pixels[row * texture.getWidth() + col] =
                        palette.getDisplayValue(lattice.get(sRect.x + col, sRect.y + row));
                }
            }

            if(recording)
                video.addFrame(Image.fromColorValues(pixels, sRect.w, sRect.h));
        }

        SDL_RenderCopy(window.getRenderer(), texture.getTexture(), &sRect, &dRect);
        SDL_RenderPresent(window.getRenderer());
    }

    void screenshot(string path)
    in
    { assert(path !is(null)); }
    body
    {
        Image image = Image.fromColorValues(texture.lock(), sRect.w, sRect.h);
        scope(exit) texture.unlock();
        
        image.saveToFile(path);
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


private:

    SDL_Rect setupDRect()
    {
        SDL_Rect dRect;

        float ratio = cast(float) (sRect.y + sRect.h) / (sRect.x + sRect.w);
        float windowRatio = cast(float) (window.getHeight()) / window.getWidth();

        if(ratio <= windowRatio)
        {
            dRect.x = 0;
            dRect.w = window.getWidth();
            dRect.y = cast(int) ((window.getHeight() - window.getWidth() * ratio) / 2);
            dRect.h = cast(int) (window.getWidth() * ratio);
        }
        else
        {
            dRect.y = 0;
            dRect.h = window.getHeight();
            dRect.x = cast(int) ((window.getWidth() - window.getHeight() * 1/ratio) / 2);
            dRect.w = cast(int) (window.getHeight() * 1/ratio);
        }

        return dRect;
    }
}



version(unittest)
{
    import caLib_abstract.renderer : isRenderer;
    import caLib_abstract.lattice : BoundedLattice;
    import caLib_abstract.palette : Palette;
}



unittest
{
    alias Ct = string;
    assert(isRenderer!(TwoDimBasicRenderer!(Ct, BoundedLattice!(Ct, 2), Palette!(Ct, Color))));
}