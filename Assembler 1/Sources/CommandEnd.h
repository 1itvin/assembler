#pragma once

#include "Headers.h"

class CommandEnd : public Command {
public:
	bool execute( Controller* controller );
};