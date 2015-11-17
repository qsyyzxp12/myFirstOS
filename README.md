# myFirstOS
movl 4(%a), %b  // 4 means the offset from the address in %a
//%ss = stack segment, 存放process記憶體的segment位置
//%sp = stack point, 用來指向process記憶體中的位置(offset)
push	%a		//將sp的值-2，然後將%a的值存入ss:[sp]中
pop		%a		//將sp的值+2, 然後將ss:[sp]中的值存入%a中
