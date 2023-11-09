#include "Robot.h"

Robot::Robot() {
	x = 0;
	y = 0;
	direction = 0;
	markers = 0;

	commands[ 0 ]	= new CommandMove();
	commands[ 1 ]	= new CommandLeft();
	commands[ 2 ]	= new CommandRight();
	commands[ 3 ]	= new CommandPickUp();
	commands[ 4 ]	= new CommandPut();
	commands[ 255 ] = new CommandEnd();
}

Robot::~Robot() {
	for ( map<unsigned char, Command*>::iterator i = commands.begin();
		  i != commands.end(); i++
		  ) {
		delete i->second;
	}
}

Command* Robot::getCommand( unsigned char code ) {
	if ( commands.find( code ) != commands.end() ) {
		return commands[ code ];
	}
	return 0;
}