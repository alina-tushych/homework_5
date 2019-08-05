-module(my_cache).
-export([create/1, insert/4, lookup/2, delete_obsolete/1]).

%Написать библыотеку для кеширования
%   1. Создание кеш таблицы (аргументы: имя таблицы).
%   2. Добавить запись в кеш (аргументы: имя таблицы, ключ, значение, время жизни записи).
%   3. Прочитать значеение по ключу (функция должна возвращать только актуальные, т.е. НЕ устаревшие данные).
%   4. Очистить из памяти все устаревшие записи.

create(TableName) -> 
    ets:new(TableName, [public, named_table]), ok.

insert(TableName, Key, Value, TTL) -> 
    EndDateSeconds = get_time_now_as_seconds() + TTL,
    ets:insert(TableName, {Key, Value, EndDateSeconds}), ok.

lookup(TableName, Key) -> 
    KVList = ets:lookup(TableName, Key),
    NowSeconds = get_time_now_as_seconds(),
    case KVList of
        [{Key, Value, EndDateSeconds}] when NowSeconds =< EndDateSeconds -> 
            {ok, Value};
        _ -> undefined
    end.

delete_obsolete(TableName) ->
    FirstKey = ets:first(TableName),
    NowSeconds = get_time_now_as_seconds(),
    <<"done">> = delete_obsolete(TableName, FirstKey, NowSeconds), 
    ok.

delete_obsolete(_TableName, '$end_of_table', _NowSeconds) ->      
    <<"done">>;

delete_obsolete(TableName, Key, NowSeconds) -> 
    NextKey = ets:next(TableName, Key),
    KVList = ets:lookup(TableName, Key),      
    case KVList of
        [{Key, _Value, EndDateSeconds}] when NowSeconds >= EndDateSeconds -> 
            ets:delete(TableName, Key);
        _ -> true
    end, 
    delete_obsolete(TableName, NextKey, NowSeconds).
    
get_time_now_as_seconds() -> 
    calendar:datetime_to_gregorian_seconds(calendar:local_time()).
        

