#include "CommandPickUp.h"

bool CommandPickUp::execute( Controller* controller ) {
	Robot* robot = controller->robot;
	Memory* memory = controller->memory;
	if ( ( *memory )[ robot->x + robot->y * 10 ] == 2 ) {
		robot->markers++;
		( *memory )[ robot->x + robot->y * 10 ] = 0;
	}
	return true;
}