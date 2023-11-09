#include "CommandPut.h"

bool CommandPut::execute( Controller* controller ) {
	Robot* robot = controller->robot;
	if ( robot->markers > 0 ) {
		Memory* memory = controller->memory;
		( *memory )[ robot->x + robot->y * 10 ] = 2;
		robot->markers--;
	}
	return true;
}