function parallelTrigger(value,pObj_handle)
% function function 
pin_values = dec2bin(value,8);
putvalue(pObj_handle,pin_values);
