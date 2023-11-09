#include "Memory.h"

Memory::Memory( unsigned int size ) {
	cells = new unsigned char[ size ];
	this->size = size;
}

Memory::~Memory() {
	delete[] cells;
}

unsigned char Memory::getSize() {
	return this->size;
}

unsigned char& Memory::operator[]( unsigned int address ) {
	if ( address < size ) {
		return cells[ address ];
	} else {
		throw "illegal address";
	}
}