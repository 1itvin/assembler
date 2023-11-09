#pragma once

#include "Headers.h"

class Robot {
private:
	map<unsigned char, Command*> commands;

public:
	unsigned char x;
	unsigned char y;
	unsigned char direction;
	unsigned char markers;

	Robot();
	~Robot();

	Command* getCommand( unsigned char code );
};