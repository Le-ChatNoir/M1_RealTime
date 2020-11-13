
with text_io;
use text_io;

procedure philosophes is 


	task mutex is
	  entry P;
	  entry V;
	end mutex;


	task type baguettes is 
		entry prendre;
		entry rendre;
	end baguettes;


	task body mutex is
	begin
		loop
			accept P;
			accept V;
		end loop;
	end mutex;


	task body baguettes is 
	begin
		loop
			accept prendre;
			accept rendre;
		end loop;
	end baguettes;


	type id is new integer range 1..3;
	B : array (id'range) of baguettes;

	task type phi(ego : id);

	task body phi is
	gauche,droite : id;
	begin
		if (ego=1) then
	   		gauche:=1; droite:=2;
		end if;
		if (ego=2) then
	   		gauche:=2; droite:=3;
		end if;
		if (ego=3) then
	   		gauche:=3; droite:=1;
		end if;
		
		loop
			put_line("Philosophe " & id'image(ego) & " pense");
			 mutex.P;    -- pour eviter l'interblocage
			B(gauche).prendre;
			put_line("Philosophe " & id'image(ego) & " alloue gauche/baquette " & id'image(gauche));
			B(droite).prendre;
			 mutex.V;    -- pour eviter l'interblocage
			put_line("Philosophe " & id'image(ego) & " alloue droite/baquette " & id'image(droite));
			put_line("Philosophe " & id'image(ego) & " mange");
			B(gauche).rendre;
			put_line("Philosophe " & id'image(ego) & " relache gauche/baquette " & id'image(gauche));
			B(droite).rendre;
			put_line("Philosophe " & id'image(ego) & " relache droite/baquette " & id'image(droite));
		end loop;
	end phi;

	P1 : phi(1);
	P2 : phi(2);
	P3 : phi(3);

begin
	null;
end philosophes;
