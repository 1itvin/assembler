#pragma once

#include "Headers.h"

class Command {
public:
	virtual bool execute( Controller* controller ) = 0;
};