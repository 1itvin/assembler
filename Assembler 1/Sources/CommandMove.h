#pragma once

#include "Headers.h"

class CommandMove : public Command {
public:
	bool execute( Controller* controller );
};