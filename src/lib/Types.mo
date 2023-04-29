/// Type declarations for the library.

import State "State";

module {
    public type Result<X> = {
        #Ok : X;
        #Err : Text;
    };
};
