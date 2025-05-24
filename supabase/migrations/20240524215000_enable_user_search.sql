-- Habilita a busca de usuários para transferências
CREATE OR REPLACE FUNCTION public.search_users(search_term text)
RETURNS SETOF users
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT *
  FROM users
  WHERE 
    email = search_term OR
    cpf = search_term OR
    telefone = search_term
  LIMIT 1;
$$;

-- Permite que usuários autenticados busquem outros usuários para transferências
CREATE POLICY "Permitir busca de usuários para transferências"
ON public.users
FOR SELECT
TO authenticated
USING (true);
