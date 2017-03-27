module caLib.renderers.OneDimBasicRenderer;

import caLib_abstract.lattice : isBoundedLattice, isAnyBoundedLattice;
import caLib_abstract.palette : isColorPalette, isAnyColorPalette;
import std.traits : CommonType;
import caLib_util.image : Image;
import caLib_util.video : Video;
import caLib_util.structs : Rect, Color;
import caLib_util.graphics;

public import caLib_util.graphics : Window;



template create_OneDimBasicRenderer(Ct, Lt, Pt)
if(isBoundedLattice!(Lt, Ct, 1) && isColorPalette!(Pt, Ct))
{
    OneDimBasicRenderer!(Ct, Lt, Pt)*
    create_OneDimBasicRenderer(Lt* lattice, Pt* palette, Window window)
    {
        return new OneDimBasicRenderer!(Ct, Lt, Pt)(lattice, palette, window);
    }
}




auto create_OneDimBasicRenderer(Lt, Pt)(Lt* lattice, Pt* palette, Window window)
if(isAnyBoundedLattice!Lt && isAnyColorPalette!Pt && Lt.Dimension == 1)
{
    alias Ct = CommonType!(Lt.CellStateType, Pt.CellStateType);
    static assert(!is(Ct == void));

    return new OneDimBasicRenderer!(Ct, Lt, Pt)(lattice, palette, window);
}



struct OneDimBasicRenderer(Ct, Lt, Pt)
if(isColorPalette!(Pt, Ct) && isBoundedLattice!(Lt, Ct, 1))
{

private:

    Lt* lattice;

    Pt* palette;

    Window window;
    Texture texture;

    uint cellSize;
    uint n;
    SDL_Rect sRectBottom;
    SDL_Rect dRectBottom;
    SDL_Rect sRectTop;
    SDL_Rect dRectTop;

public:

    this(Lt* lattice, Pt* palette, Window window)
    in
    {
        assert(window.getWidth() / lattice.getLatticeBounds()[0] > 0);
    }
    body
    {
        this.lattice = lattice;
        this.palette = palette;

        this.window = window;

        cellSize = window.getWidth() / lattice.getLatticeBounds()[0];
        n=0;

        texture = new Texture(window, lattice.getLatticeBounds()[0], window.getHeight() / cellSize);

        sRectBottom = SDL_Rect(0, 0, texture.getWidth(), n+1);
		dRectBottom = SDL_Rect(0, window.getHeight() - (n+1)*cellSize, window.getWidth(), (n+1)*cellSize);
		sRectTop = SDL_Rect(0, n+1, texture.getWidth(), texture.getHeight() - (n+1));
		dRectTop = SDL_Rect(0, 0, window.getWidth(), window.getHeight() - (n+1)*cellSize);
    }

    void render()
    {
    	{
    		uint* pixels = texture.lock();
    		scope(exit) texture.unlock();

    		foreach(col; 0 .. texture.getWidth())
    		{
    			pixels[n * texture.getWidth() + col] = palette.getDisplayValue(lattice.get(col));
    		}
    	}

		sRectBottom.h = n+1;
		dRectBottom.y = window.getHeight() - (n+1) * cellSize;
		dRectBottom.h = (n+1) * cellSize;
		SDL_RenderCopy(window.getRenderer(), texture.getTexture(), &sRectBottom, &dRectBottom);

		sRectTop.y = n+1;
		sRectTop.h = texture.getHeight() - (n+1);
		dRectTop.h = window.getHeight() - (n+1) * cellSize;
		SDL_RenderCopy(window.getRenderer(), texture.getTexture(), &sRectTop, &dRectTop);

        SDL_RenderPresent(window.getRenderer());

        n ++;

        if(n >= texture.getHeight())
        	n=0;
    }

    void screenshot(string path)
    in
    { assert(path !is(null)); }
    body
    {
    	uint* pixels = texture.lock();
    	scope(exit) texture.unlock();

    	Image image = new Image(texture.getWidth(), texture.getHeight());
    	foreach(row; 0 .. texture.getHeight())
    	{
    		foreach(col; 0 .. texture.getWidth())
    		{
    			image.setPixel(col, row, Color(pixels[(n + row) % texture.getHeight() * texture.getWidth() + col]));
    		}
    	}
    	image.saveToFile(path);
    }

    void startRecording(string path, uint framerate)
    {
        assert(0);
    }
    
    void stopRecording()
    {
        assert(0);
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
    assert(isRenderer!(OneDimBasicRenderer!(Ct, BoundedLattice!(Ct, 1), Palette!(Ct, Color))));
}