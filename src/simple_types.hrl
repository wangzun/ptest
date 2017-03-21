-ifndef(_simple_types_included).
-define(_simple_types_included, yeah).

%% struct location

-record(location, {region :: string() | binary(),
                   country :: string() | binary()}).

%% struct person

-record(person, {name :: string() | binary(),
                 address :: string() | binary(),
                 phone_number :: string() | binary(),
                 groups :: list(),
                 age :: integer(),
                 location :: #location{}}).

-endif.
