-module(point).
-include_lib("eunit/include/eunit.hrl").
-export([at_line/2, shift/2, sum/2, neg/1, mirror/2, str/1]).
-author("ea1a87").


-type point():: {point, number(), number()}.	%% Точка в двухмерном пространстве
-type line() ::	{line	, point()	, point()	}.	%% Прямая на плоскости проходящая заданная двумя точками

%% @doc Возвращает новую точку заданную координатами X,Y
-spec new( number(), number() ) -> point().
new(X,Y)		-> 
	if
		is_number(X) and is_number(Y) -> {point, float(X), float(Y)};
		true													-> error(badpoint)
end.
new_test()	-> ?_assert(new(10,30)		  =:= {point, 10, 30}).
new_test()	-> ?_assert(new([90,90],30) =:= {error, badpoint}).

%% TODO: UNTESTED
%% @doc Проверяет лежит ли точка на прямой. Возвращает true/false
-spec at_line( line(), point() ) -> atom(). 
at_line(Line, A)	 ->
	{point, X, Y} = A,
	Y1 = line:find('y?', Line, X),
	if
		Y /= Y1 -> false;
		true		-> true
	end
.
at_line_test_()		-> [
	?_assert(at_line(	{ line, {point,  0, 0},{point,-10, 10}},{point,-5, 5}) =:= true ),
	?_assert(at_line(	{ line, {point, 10, 0},{point, 20, 10}},{point,15, 5}) =:= true ),
	?_assert(at_line(	{ line, {point, 10, 0},{point, 20, 10}},{point,16, 5}) =:= false)
].

%% @doc			Складывает две точки. Возвращает точку с координатами (X1+X2,Y1+Y2).
-spec shift( point(), point() )->point().
shift(A, B)	 ->
	{point, Xa, Ya} = A,
	{point, Xb, Yb} = B,
	{point, Xa+Xb, Ya+Yb}.
shift_test() -> ?_assert( shift( {point, 30, 72.3},{point,-30.75, 9} ) =:= {point, -0.75, 81.3} ).

%% @doc			Складывает две точки. Возвращает точку с координатами (X1+X2,Y1+Y2).
-spec sum( A::point(), B::point() )->point().
sum(A, B) -> shift(A, B).


%% @doc			Зеркалирует точку относительно начала координат / Умножает точку на -1. Возвращает точку с координатами (-X,-Y).
-spec neg( point() )->point().
neg(A)		 ->
	{point,	 X,	 Y} = A,
	{point,	-X, -Y}.
neg_test() -> ?_assert( neg({point, 15, 3}) =:= {point, -15, -3} ).

%% @doc			Отзеркаливает точку относительно прямой. Точку с координатами (X1, Y1) зеркальную заданной. 
%% 					Подробности на поясняющем рисунке
-spec mirror( line(), point() ) -> point().
mirror(Line, A) ->
	{point, Xa, Ya}= A,
	D1	=	point:new(0, Ya),
	D2	=	point:new(Xa, 0),
	C1	= line:intersect(Line, line:new(D1, A)),
	C2	= line:intersect(Line, line:new(D2, A)),
	AC1	= line:len(line:new(A, C1)),
	AC2	= line:len(line:new(A, C2)),
	A		= math:atan(AC1/AC2),
	DX			= AC1 * math:sin(A)*direction(x, A, C1).
	DY			= math:sqrt(4 * AC1 * AC1 * math:pow(math:sin(A), 2) - (DX * DX )) * direction(y, A, C2),
	shift(A, {point, DX, DY}).
mirror_test_()	-> [
	?_assert(at_line(	{ line, {point,  0, 0},{point,100,100} },{point, 50, 40}) =:= {point, 40, 50} ),
	?_assert(at_line(	{ line, {point,  0, 0},{point,-10,-10} },{point,-40,-80}) =:= {point,-80,-40} )
].

%% @doc Направление отрезка по соответствующей оси
direction(x, A, B) ->
	{point, Xa, _ } = A,
	{point, Xb, _ } = B,
	(Xb-Xa)/abs(Xa-Xb);
direction(y, A, B) ->
	{point, _, Ya } = A,
	{point, _, Yb } = B,
	(Yb-Ya)/abs(Ya-Yb).
direction_test_() -> [
	?assert(direction( x, { point, 10, 10}, {point, 20, 20} ) =:= 1 ),
	?assert(direction( x, { point, 10, 10}, {point, 00, 20} ) =:=-1 ),
	?assert(direction( x, { point, 10, 10}, {point, 10, 20} ) =:= 0 ),
	?assert(direction( y, { point, 10, 10}, {point, 10, 20} ) =:= 1 ),
	?assert(direction( y, { point, 10, 10}, {point, 10, 00} ) =:=-1 ),
	?assert(direction( y, { point, 10, 10}, {point, 30, 10} ) =:= 0 )

%% @doc Переводит точку в обычную (небинарную) строку вида "X,Y".
-spec str( point() ) -> string() .
str(A)		 ->
 {point, X, Y} = A,
 [round(X), ",", round(Y)].
str_test() -> ?_assert({point, 9666, 0.13}) =:= [9666, ",", 0.13]).
