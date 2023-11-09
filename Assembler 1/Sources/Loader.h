#pragma once

#include "Headers.h"

class Loader {
private:
	vector<unsigned char> content;

public:
	Loader( const char* fileName );

	unsigned int load( Memory* memory, unsigned int writePointer );

};