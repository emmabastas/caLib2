module caLib.palettes.ColorListPalette;

import caLib_util.structs : Color;



auto create_ColorListPalette(Ct)(Color[Ct] colors)
in
{
	assert(colors !is null);
}
body
{
	return create_ColorListPalette!(Ct)(colors, Color.init);
}



auto create_ColorListPalette(Ct)(Color[Ct] colors, Color defaultValue)
in
{
	assert(colors !is null);
}
body
{
	return new ColorListPalette!(Ct)(colors, defaultValue);
}



struct ColorListPalette(Ct)
{

private:

	Color[Ct] colors;
	Color defaultValue;

public:

	alias CellStateType = Ct;
	alias DisplayValueType = Color;

	this(Color[Ct] colors, Color defaultValue)
	in
	{
		assert(colors !is null);
	}
	body
	{
		this.colors = colors;
		this.defaultValue = defaultValue;
	}

	Color getDisplayValue(string behaviour)(Ct cellState)
	{
		static if(behaviour == "withDefaultValue")
		{
			return colors.get(cellState, defaultValue);
			//auto ptr = cellState in colors;
			//return ptr ? *ptr : defaultValue;
		}
		else static if(behaviour == "assumeEntryExists")
		{
			return colors[cellState];
		}
		else static if(behaviour == "_test")
		{
			return Color.init;
		}
		else
		{
			static assert(0, "ColorListPalette getDisplayValue method dosen't"
				~ "have a \"" ~ behaviour ~"\" behaviour");
		}
	}

	Color getDisplayValue()(Ct cellState)
	{
		return getDisplayValue!"withDefaultValue"(cellState);
	}
}

version(unittest)
{
	import caLib_abstract.palette : isColorPalette;
}

unittest
{
	static assert( isColorPalette!(ColorListPalette!(int), int));
}