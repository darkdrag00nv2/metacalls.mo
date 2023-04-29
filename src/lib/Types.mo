/// Type declarations for the library.

import State "State";

module {
    public type CreateDerivedIdentityResponse = {
        key_name : Text;
    };

    public type Result<X> = {
        #Ok : X;
        #Err : Text;
    };
};
