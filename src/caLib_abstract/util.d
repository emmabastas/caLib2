/**
* This module is contains utility templates used by the other modules in
* $(CALIB_ABSTRACT).
*
* Take a look the various modules in $(CALIB_ABSTRACT) for usage examples.
*/

module caLib_abstract.util;



/**
* return `true` if `T` has an `alias` named `CellStateType`. `False` if not
*/
template hasCellStateType(T)
{
	enum hasCellStateType =
		is(T.CellStateType) &&
		is(T.init.CellStateType);
}

///
unittest
{
	struct Foo {
		alias CellStateType = void;
	}

	static assert( hasCellStateType!Foo);
	static assert(!hasCellStateType!string);
}



/**
* Return true all of the given arguments are types that can be impliciltly
* converted to one-another
*
* It is unclear if it behaves the way it should in all cases and should
* not be used .
*/
deprecated template isCellStateTypesCompatible(T...)
{
	static assert(T.length != 0);

	static if(T.length == 1)
	{
		enum isCellStateTypesCompatible = true;
	}
	else
	{
		enum isCellStateTypesCompatible =
			__traits(compiles, (() {
						static assert(is(T[0] : T[1]));
					})() ) &&
			isDimensionsCompatible!(T[1..$]);
	}
}

///
unittest
{
	static assert( isCellStateTypesCompatible!(int));
	static assert( isCellStateTypesCompatible!(int, uint));
	static assert(!isCellStateTypesCompatible!(int, string));
}



/**
* return `true` if `T` has an `alias` named `DisplayValueType`. `False` if not
*/
template hasDisplayValueType(T)
{
	enum hasDisplayValueType =
		is(T.DisplayValueType) &&
		is(T.init.DisplayValueType);
}

///
unittest
{
	struct Foo {
		alias DisplayValueType = uint;
	}

	static assert( hasDisplayValueType!Foo);
	static assert(!hasDisplayValueType!string);
}



/**
* Return true all of the given arguments are types that can be impliciltly
* converted to one-another
*
* It is unclear if it behaves the way it should in all cases and should
* not be used .
*/
deprecated template isDisplayValueTypesCompatible(T...)
{
	static assert(T.length != 0);

	static if(T.length == 1)
	{
		enum isCellStateTypesCompatible = true;
	}
	else
	{
		enum isCellStateTypesCompatible =
			__traits(compiles, (() {
						static assert(is(T[0] : T[1]));
					})() ) &&
			isDimensionsCompatible!(T[1..$]);
	}
}

///
unittest
{
	static assert( isCellStateTypesCompatible!(int));
	static assert( isCellStateTypesCompatible!(int, uint));
	static assert(!isCellStateTypesCompatible!(int, string));
}



/**
* return `true` if `T` has an `enum uint` named `Dimension`. `False` if not
*/
template hasDimension(T)
{
	enum hasDimension =
		is(typeof(T.Dimension) : int) &&
		is(typeof(T.init.Dimension) : int);
}

///
unittest
{
	struct Foo {
		static immutable int Dimension = 0;
	}

	static assert( hasDimension!Foo);
	static assert(!hasDimension!int);
}



/**
* Return true all of the given arguments are types that can be impliciltly
* converted to one-another
*
* It is unclear if it behaves the way it should in all cases and should
* not be used .
*/
deprecated template isDimensionsCompatible(T...)
{
	static assert(T.length != 0);

	static if(T.length == 1)
	{
		enum isDimensionsCompatible = true;
	}
	else
	{
		enum isDimensionsCompatible =
			__traits(compiles, (() {
						static assert(T[0] == T[1]);
					})() ) &&
			isDimensionsCompatible!(T[1..$]);
			
	}
}

///
unittest
{
	static assert( isDimensionsCompatible!(0));
	static assert( isDimensionsCompatible!(0, 0u));
	static assert( isDimensionsCompatible!(0, 0u, byte(0)));
	static assert(!isDimensionsCompatible!(0, 0.1f));
}



/**
* return `true` if `T` has an `alias` named `NeighbourhoodType`. `False` if not
*
* return `true` if `T` has an `alias` named `NeighbourhoodType`. `False` if not.
* $(B Note) that `NeighbourhoodType` need not actually be a neighbourhood.
* It can be any type
*/
template hasNeighbourhoodType(T)
{
	enum hasNeighbourhoodType =
		is(T.NeighbourhoodType) &&
		is(T.init.NeighbourhoodType);
}

///
unittest
{
	struct Foo {
		alias NeighbourhoodType = char; //car is is not a neighbourhood
	}

	static assert( hasNeighbourhoodType!Foo); //but this return true anyways
	static assert(!hasNeighbourhoodType!int);
}
