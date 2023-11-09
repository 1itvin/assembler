#include "Controller.h"

Controller::Controller(
	Robot*		robot,
	Memory*		memory,
	Loader*		mapLoader,
	Loader*		programLoader,
	Display*	display,
	Keyboard*	keyboard
) {
	commandAddress = 0;
	step = 0;
	this->robot			= robot;
	this->memory		= memory;
	this->mapLoader		= mapLoader;
	this->programLoader = programLoader;
	this->display		= display;
	this->keyboard		= keyboard;
}

Controller::~Controller() {
	delete robot;
	delete memory;
	delete mapLoader;
	delete programLoader;
	delete display;
	delete keyboard;
}

void Controller::execute() {
	commandAddress = mapLoader->load( memory, 0 );
	programLoader->load( memory, commandAddress );
	bool running = true;
	unsigned char code;
	Command* command;

	system( "cls" );
	display->print( this );
	keyboard->readKey();

	while ( running ) {
		code = ( *memory )[ commandAddress ];
		command = robot->getCommand( code );

		if ( command ) {
			commandAddress++;
			step++;
			running = command->execute( this );
			system( "cls" );
			display->print( this );
			keyboard->readKey();
		} else {
			throw "illegal operation code";
		}
	}
}