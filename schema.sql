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

CREATE TABLE events (
  id serial PRIMARY KEY,
  name text NOT NULL,
  date text NOT NULL,
  time text NOT NULL,
  price text NOT NULL,
  description text NOT NULL
);

INSERT INTO events (name, date, time, price, description) VALUES
  ('Argentinian Wine Tasting', '10/13/2020', '06:30pm - 07:30pm',
   'Free', 'Come join us for a tasting of wines from Argentina. Señor Vino has been making wine in the Mendoza region of Argentina for 20 years. The high altitude provides excellent growing conditions for Malbec and Torrontes, the two grape varieties planted at his vineyard.'),
  ('Paint and Sip', '10/25/2020', '07:00pm - 08:00pm', '$25',
   'Learn how to paint while enjoying a glass of wine! This week we have local artist Banksy joining us in a guided painting of a red balloon. In keeping with tradition, the painting must be shredded upon completion. The remains will be packaged in a to go bag to remember the event.');
