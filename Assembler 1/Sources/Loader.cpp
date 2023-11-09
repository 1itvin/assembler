#include "Loader.h"

Loader::Loader( const char* fileName ) {
	ifstream fin( fileName );
	if ( fin.is_open() ) {
		int number;
		while ( fin >> number ) {
			content.push_back( (unsigned char)number );
		}
		fin.close();
	} else {
		throw "file not found";
	}
}

unsigned int Loader::load( Memory * memory, unsigned int writePointer ) {
	for ( vector<unsigned char>::iterator i = content.begin();
		  i != content.end(); i++
		  ) {
		( *memory )[ writePointer++ ] = *i;
	}
	return writePointer;
}
