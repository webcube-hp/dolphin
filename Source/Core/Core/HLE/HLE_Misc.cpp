// Copyright 2013 Dolphin Emulator Project
// Licensed under GPLv2
// Refer to the license.txt file included.

#include <cmath>

#include "Common/CommonPaths.h"
#include "Common/CommonTypes.h"

#include "Core/ConfigManager.h"
#include "Core/Host.h"
#include "Core/Boot/Boot_DOL.h"
#include "Core/HLE/HLE.h"
#include "Core/HLE/HLE_Misc.h"
#include "Core/HLE/HLE_OS.h"
#include "Core/HW/Memmap.h"
#include "Core/IPC_HLE/WII_IPC_HLE_Device_DI.h"
#include "Core/IPC_HLE/WII_IPC_HLE_Device_usb.h"
#include "Core/PowerPC/PowerPC.h"
#include "Core/PowerPC/PPCAnalyst.h"
#include "Core/PowerPC/PPCCache.h"
#include "Core/PowerPC/PPCSymbolDB.h"
#include "Core/PowerPC/SignatureDB.h"

#include "DiscIO/Filesystem.h"
#include "DiscIO/VolumeCreator.h"

#include "VideoCommon/TextureCacheBase.h"

namespace HLE_Misc
{

static std::string args;

// If you just want to kill a function, one of the three following are usually appropriate.
// According to the PPC ABI, the return value is always in r3.
void UnimplementedFunction()
{
	NPC = LR;
}

// If you want a function to panic, you can rename it PanicAlert :p
// Don't know if this is worth keeping.
void HLEPanicAlert()
{
	::PanicAlert("HLE: PanicAlert %08x", LR);
	NPC = LR;
}

void HBReload()
{
	// There isn't much we can do. Just stop cleanly.
	PowerPC::Pause();
	Host_Message(WM_USER_STOP);
}

void HLEGeckoCodehandler()
{
	// Work around the codehandler not properly invalidating the icache, but
	// only the first few frames.
	// (Project M uses a conditional to only apply patches after something has
	// been read into memory, or such, so we do the first 5 frames.  More
	// robust alternative would be to actually detect memory writes, but that
	// would be even uglier.)
	u32 magic = 0xd01f1bad;
	u32 existing = Memory::Read_U32(0x80001800);
	if (existing - magic == 5)
	{
		return;
	}
	else if (existing - magic > 5)
	{
		existing = magic;
	}
	Memory::Write_U32(existing + 1, 0x80001800);
	PowerPC::ppcState.iCache.Reset();
}

}
