CREATE TABLE wine (
  id serial PRIMARY KEY,
  type text NOT NULL CHECK (type = 'red' OR type = 'white' OR type = 'bubbly'),
  name text NOT NULL
);

INSERT INTO wine (type, name) VALUES
  ('red', 'Screaming Eagle Cabernet Sauvignon, 1992, Oakville, Napa Valley, CA'),
  ('red', 'DRC Romanee-Conti, 1995, Vosne-Romaneè, Burgundy, France'),
  ('red', 'Vietti Ravera, 2001, Barolo, Italy'),
  ('red', 'Chateau Petrus, 1975, Pomerol, Bourdeaux, France'),
  ('red', 'Penfolds Grange, 1999, South Australia'),
  ('white', 'Domaine Leflaive Montrachet, 2007, Puligny-Montrachet, Burgundy, France'),
  ('white', 'Chateau Montalena Chardonnay 2012, Napa Valley, CA'),
  ('white', 'Domaine Georges Vernay, 2017, Condrieu, Rhone, France'),
  ('white', 'Egon Müller Scharzhofberger Riesling Auslese, 2014, Mosel, Germany'),
  ('white', 'Seresin Marama Sauvignon Blanc, 2013, Marlborough, New Zealand'),
  ('bubbly', 'Dom Perignon Brut, 2002, Champagne, France'),
  ('bubbly', 'Schramsberg Brut Rose, 2017, Napa Valley, CA');
