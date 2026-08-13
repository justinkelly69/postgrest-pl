CREATE FUNCTION api.add_them(a integer, b integer)
RETURNS integer AS $$
 SELECT a + b;
$$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION api.greet_user(username TEXT DEFAULT 'guest')
RETURNS TEXT AS $$
  SELECT 'Hello ' || username || '!';
$$ LANGUAGE SQL IMMUTABLE;
