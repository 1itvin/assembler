#pragma once

#include "Headers.h"

class Memory {
private:
	unsigned int	size;
	unsigned char*	cells;

public:
	Memory( unsigned int size );
	~Memory();

	unsigned char getSize();
	unsigned char& operator[]( unsigned int address );
};