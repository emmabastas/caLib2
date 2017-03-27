/**
* This module defines the notion of a $(PALETTE). $(PALETTE)s abstract the
* process of determining how to render the $(I cells) in a $(LATTICE) by the
* $(RENDERER), Allowing for more customization.
*
* It provides templates for testing whether a given object is a $(PALETTE),
* and what kind of $(PALETTE) it is.
*
* $(CALIB_ABSTRACT_DESC)
*
* Macros:
* IS_ANY = 
*     Tests if something is a $(B $0).
*     $(DDOC_BLANKLINE)
*     returns $(DDOC_BACKQUOTED true) if $(DDOC_BACKQUOTED T) is a $(B $0) where
*     the value specifing how a $(RENDERER) should display a $(I cell) can be of
*     any type. The $(I cell) can also be of any type.
*     $(DDOC_BLANKLINE)
*     This template is the same as $(B is$0) but the type of the display-value and
*     type of the $(I cells) need not be specified. Refer to $(B is$0) for more details about
*     what a $(B $0) is.
*     $(DDOC_BLANKLINE)
*     $(DDOC_PARAMS T type to be tested)
*     $(DDOC_RETURNS $(B true) if $(B T) is any $(B $0), $(B false) if not)
*/

module caLib_abstract.palette;

import caLib_abstract.util : hasCellStateType, isCellStateTypesCompatible,
    hasDisplayValueType, isDisplayValueTypesCompatible;
import caLib_util.structs : Color;



/**
* Tests if something is a $(B Palette).
*
* Returns `true` if `T` is a $(B Palette) where `Dv` is the type of the value
* specifing how a $(RENDERER) should display a $(I cell) of type `Ct`
*
* A $(B Palette) is the most basic for of a $(PALETTE) defining the primitives: $(BR)
* `Dv getDisplayValue(string behaviour)(Ct cellState)` and
* `Dv getDisplayValue(Ct cellState)` where `Dv` is the type of the value describing
* how the cell `cellState` of type `Ct` should be rendererd.
*
* Params:
*	  T  = type to be tested
*     Ct = type of the cell
*     Dv = type whoms value describes how a cell of type Ct should be rendererd
*
* Returns: true if T is a $(B Neighbourhood), false if not
*/
template isPalette(T, Ct, Dv)
{
	enum isPalette = 
		hasCellStateType!T &&
		hasDisplayValueType!T &&
		is(typeof(T.init.getDisplayValue!"_test"(Ct.init)) : Dv) &&
		is(typeof(T.init.getDisplayValue(Ct.init)) : Dv);
}

unittest
{
	static assert( isPalette!(Palette!(string, byte), string, byte));
	static assert( isPalette!(Palette!(string, int), string, uint));
	static assert(!isPalette!(Palette!(string, int), int, string));
	static assert(!isPalette!(char[], int, int));
}



///$(IS_ANY Palette)
template isAnyPalette(T)
{
	static if(hasCellStateType!T && hasDisplayValueType!T)
	{
		enum isAnyPalette = isPalette!(T, T.CellStateType, T.DisplayValueType);
	}
	else
	{
		enum isAnyPalette = false;
	}
}

unittest
{
	static assert( isAnyPalette!(Palette!(int, uint)));
	static assert(!isAnyPalette!string); 
}



/// Example of a $(B Palette)
struct Palette(Ct, Dv)
{	
	alias CellStateType = Ct;
	alias DisplayValueType = Dv;

	Dv getDisplayValue(string behaviour)(Ct cellState) { return Dv.init; }
	Dv getDisplayValue(Ct cellState) { return Dv.init; }
}

///
unittest
{
	alias palette = Palette!(int, char);

	assert(isPalette!(palette, int, char));
	assert(isAnyPalette!(palette));
}



/**
* Convinience template, same as $(B isPalette) but `Dv` is set to be of type
*`Color`.
*
* In almost all cases a $(PALETTE) will decide in what color a $(RENDERER) should
* render the $(LATTICE)s $(I cells). Thus this enum is added for convinience.
*/
enum isColorPalette(T, Ct) = isPalette!(T, Ct, Color);



///$(IS_ANY ColorPalette)
template isAnyColorPalette(T)
{
	static if(hasDisplayValueType!T && is(T.DisplayValueType == Color))
	{
		enum isAnyColorPalette = isAnyPalette!(T);
	}
	else
	{
		enum isAnyColorPalette = false;
	}
}

///
unittest
{
	// a palette template
	struct A(Ct, Dv) {
		Dv getDisplayValue(string behaviour)(Ct cellState) {
			return Ct.init;
		}

		Dv getDisplayValue(Ct cellState) { return getDisplayValue!""(cellState); }
	}

	bool a =       isAnyPalette!(A!(int, byte)); // true for any values of A
	bool b = !isAnyColorPalette!(A!(int, int )); // false since A!(int, int ) does not return uint 
	bool c = !isAnyColorPalette!(A!(int, uint)); // true  since A!(int, uint) does     return uint
}



/// Example of a $(B ColorPalette)
struct ColorPalette(Ct)
{	
	alias CellStateType = Ct;
	alias DisplayValueType = Color;

	Color getDisplayValue(string behaviour)(Ct cellState) { return Color(0); }
	Color getDisplayValue(Ct cellState) { return Color(0); }
}

///
unittest
{
	alias palette = ColorPalette!(int);

	assert(isPalette!(palette, int, Color));
	assert(isColorPalette!(palette, int));
	assert(isAnyColorPalette!(palette));
}
