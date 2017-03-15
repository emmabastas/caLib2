module caLib.lattices.TwoDimMargolusBlockLattice;

//import caLib_abstract.Base;

//import caLib_abstract.Lattice;
//import caLib_abstract.latticeDecorators.BlockLattice;
//import caLib_abstract.latticeDecorators.BoundedLattice;

//import caLib.neighbourhoods.TwoDimMargolusNeighbourhood;

import caLib_util.misc : mod;

import std.stdio;

template create_TwoDimMargolusBlockLattice(CellStateType)
{
    alias Ct = CellStateType;

    auto create_TwoDimMargolusBlockLattice(int width, int height)
    {
        return new TwoDimMargolusBlockLattice!(Ct)(width, height);
    }

    auto create_TwoDimMargolusBlockLattice(int width, int height,
        CellStateType emptyCellState, CellStateType initialCondition)
    {
        return new TwoDimMargolusBlockLattice!(Ct)(width, height, emptyCellState,
        	initialCondition);
    }

    auto create_TwoDimMargolusBlockLattice(int width, int height, CellStateType emptyCellState, 
    	CellStateType delegate(int x, int y) initialCondition)
    {
        return new TwoDimMargolusBlockLattice!(Ct)(width, height,
            emptyCellState, initialCondition);
    }
}

struct TwoDimMargolusBlockLattice(CellStateType)
{
    /*
    * get behaviours
    *     "torus"
    *     "bounded"
    *     "bounded-assumeInBounds"
    *
    * set behaviours
    *     "torus"
    *     "bounded"
    *     "bounded-assumeInBounds"
    *
    * getNeighbours behaviours
    *     "torus"
    *     "bounded"
    *     "bounded-assumeInBounds"
    *
    * iterate behaviours
    *     "all"
    *
    * nextGen behaviours
    *     "correct"
    *     "toggle"
    *     "flipp"
    *
    * getBlock behaviours
    *     "torus"
    *     "bounded"
    *     "bounded-assumeInBounds"
    *
    * setBlock behaviours
    *     "torus"
    *     "bounded"
    *     "bounded-assumeInBounds"
    */

private:

	alias Ct = CellStateType;

	TwoDimMargolusNeighbourhood* neighbourhood;

	int width;
	int height;

    int blocksWidth;
    int blocksHeight;

	Ct[] lattice;

	Ct emptyCellState;

public:

	Base!(TwoDimLattice!Ct
		, TwoDimBlockLattice!Ct
		, TwoDimBoundedLattice) base;
	alias base this; 

	this(int width, int height)
    {
        this(width, height, Ct.init, Ct.init);
    }

    this(int width, int height, Ct emptyCellState, Ct initialCondition)
    {
        auto initialConditionFunc = (int x, int y) { return initialCondition; };
        this(width, height, emptyCellState, initialConditionFunc);
    }

    this(int width, int height, Ct emptyCellState, Ct delegate(int x, int y) initialCondition)
    in
    { assert(width > 0 && height > 0); }
    body
    {
    	this.width = width + ((width & 1) == 1 ? 1 : 0);
    	this.height = height + ((height & 1) == 1 ? 1 : 0);

    	this.neighbourhood = new TwoDimMargolusNeighbourhood();

    	this.emptyCellState = emptyCellState;

    	this.lattice.length = this.width * this.height;
    	foreach(row; 0 .. this.height)
    	{
    		foreach(col; 0 .. this.width)
    		{
    			lattice[row * this.width + col] = initialCondition(col, row);
    		}
    	}
    }

    Ct get(string behaviour)(int x, int y)
    {
        static if(behaviour == "torus")
        {
            return lattice.ptr[mod(y, height) * width + mod(x, width)];
        }
        else static if(behaviour == "bounded")
        {
            if(x >= 0 && x < width && y >= 0 && y < height)
            {
                return lattice.ptr[y * width + x];
            }
            else
            {
                return emptyCellState;
            }
        }
        else static if(behaviour == "bounded-assumeInBounds")
        {
            return lattice.ptr[y * width + x];
        }
        else
        {
            return base.get!behaviour(x, y);
        }
    }

    Ct get(int x, int y)
    {
        return get!"bounded"(x, y);
    }

    void set(string behaviour)(int x, int y, Ct newValue)
    {
        static if(behaviour == "torus")
        {
            lattice.ptr[mod(y, height) * width + mod(x, width)] = newValue;
        }
        else static if(behaviour == "bounded")
        {
            if(x >= 0 && x < width && y >= 0 && y < height)
            {
                lattice.ptr[y * width + x] = newValue;
            }
        }
        else static if(behaviour == "bounded-assumeInBounds")
        {
            lattice.ptr[y * width + x] = newValue;
        }
        else
        {
            base.set!behaviour(x, y);
        }
    }

    void set(int x, int y, Ct newValue)
    {
        set!"bounded"(x, y, newValue);
    }

    Ct[] getNeighbours(string behaviour)(int x, int y)
    {
        static if(behaviour == "torus"
               || behaviour == "bounded"
               || behaviour == "bounded-assumeInBounds")
        {
            Ct[] neighbours;
            foreach(coord ; neighbourhood.getNeighboursCoordinates(x, y))
            {
                neighbours ~= [get!behaviour(coord[0], coord[1])];
            }
            return neighbours;
        }
        else
        {
            return base.getNeighbours!behaviour(x, y);
        }
    }

    Ct[] getNeighbours(int x, int y)
    {
        return getNeighbours!"bounded"(x, y);
    }

    void iterate(string behaviour)(void delegate(int x, int y) iterator)
    {
        static if(behaviour == "all")
        {
            for(int row=0; row<height; row++) {
                for(int col=0; col<width; col++) {
                    iterator(col, row);
                }
            }
        }
        else
        {
            base.iterate!behaviour(iterator);
        }
    }

    void iterate(void delegate(int x, int y) iterator)
    {
        iterate!"all"(iterator);
    }

    void nextGen(string behaviour)()
    {
        static assert(0, "Error, this method cannot be used with this lattice");
    }

    void nextGen()
    {
        neighbourhood.shift();
    }

    Ct[] getBlock(string behaviour)(int x, int y)
	{
        static if(behaviour == "torus"
               || behaviour == "bounded" 
               || behaviour == "bounded-assumeInBounds")
        {
            int[] block;

            foreach(coord; neighbourhood.getBlockCoordinates(x, y))
            {
                block = [get!behaviour(coord[0], coord[1])] ~ block;
            }
            return block;
        }
        else
        {
            return base.getBlock!behaviour(x, y);
        }	
	}

	Ct[] getBlock()(int x, int y)
	{
		return getBlock!"bounded"(x, y);
	}

	void setBlock(string behaviour)(int x, int y, Ct[] newBlock)
	{
		static if(behaviour == "torus"
               || behaviour == "bounded" 
               || behaviour == "bounded-assumeInBounds")
        {
            foreach(coord; neighbourhood.getBlockCoordinates(x, y))
            {
                set!behaviour(coord[0], coord[1], newBlock[0]);
                newBlock = newBlock[1..newBlock.length];
            }
        }
        else
        {
            return base.setBlock!behaviour(x, y);
        }
	}

	void setBlock()(int x, int y, Ct[] newBlock)
	{
		setBlock!"bounded"(x, y, newBlock);	
	}

	void iterateBlocks(string behaviour)(void delegate(int x, int y) iterator)
	{
		static if(behaviour == "all")
        {
            foreach(row; 0 .. width/2)
            {
                foreach(col; 0 .. height/2)
                {
                    iterator(col, row);
                }
            }
        }
        else
        {
            base.iterateBlocks!"behaviour"(iterator);
        }
	}

	void iterateBlocks()(void delegate(int x, int y) iterator)
	{
		iterateBlocks!"all"(iterator);	
	}

	Size[2] getLatticeSize()()
	{
		return [Size(0, width), Size(0, height)];
	}
}