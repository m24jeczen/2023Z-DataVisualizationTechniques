library(dplyr)

df <- read.csv("house_data.csv")

colnames(df)
dim(df)
apply(df, 2, function(x) sum(is.na(x))) # nie ma warto�ci NA w �adnej kolumnie

# 1. Jaka jest �rednia cena nieruchomo�ci z liczb� �azienek powy�ej mediany i po�o�onych na wsch�d od po�udnika 122W?
mediana_�az = median(df$bathrooms)
df %>% 
  filter(bathrooms>mediana_�az & long>(-122)  & long<180) %>% 
  select(price) %>% 
  summarise(mean=mean(price))

# Odp: 625499.4 USD

# 2. W kt�rym roku zbudowano najwi�cej nieruchomo�ci?

df %>% 
  group_by(yr_built) %>% 
  summarise(n = n()) %>% 
  top_n(1, n)


# Odp: 2014

# 3. O ile procent wi�ksza jest mediana ceny budynk�w po�o�onych nad wod� w por�wnaniu z tymi po�o�onymi nie nad wod�?

med_nad_wod=df %>% 
  filter(waterfront==1) %>% 
  select(price) %>% 
  summarise(median=median(price))

med_nad_wod

med_nienad_wod=df %>% 
  filter(waterfront==0) %>% 
  select(price) %>% 
  summarise(median=median(price))

med_nienad_wod

med_nad_wod/med_nienad_wod*100-100

# Odp: Wi�ksza o 211,1111 procent

# 4. Jaka jest �rednia powierzchnia wn�trza mieszkania dla najta�szych nieruchomo�ci posiadaj�cych 1 pi�tro (tylko parter) wybudowanych w ka�dym roku?
df %>% 
  filter(floors==1) %>% 
  group_by(yr_built) %>% 
  filter(price == min(price)) %>% 
  ungroup() %>% 
  summarise(mean(sqft_living))
  
  
  

# Odp: 1030

# 5. Czy jest r�nica w warto�ci pierwszego i trzeciego kwartyla jako�ci wyko�czenia pomieszcze� pomi�dzy nieruchomo�ciami z jedn� i dwoma �azienkami? Je�li tak, to jak r�ni si� Q1, a jak Q3 dla tych typ�w nieruchomo�ci?
x=df %>% 
  filter(bathrooms==1 | bathrooms==2) %>% 
  select(grade)

x=x$grade

quantile(x, prob=c(0.25, 0.75))


# Odp: Jest r�nica, Q1=6, Q3=7

# 6. Jaki jest odst�p mi�dzykwartylowy ceny mieszka� po�o�onych na p�nocy a jaki tych na po�udniu? (P�noc i po�udnie definiujemy jako po�o�enie odpowiednio powy�ej i poni�ej punktu znajduj�cego si� w po�owie mi�dzy najmniejsz� i najwi�ksz� szeroko�ci� geograficzn� w zbiorze danych)
min=df %>% 
  select(lat) %>% 
  arrange(lat) %>%
  head(1)

max=df %>% 
  select(lat) %>% 
  arrange(-lat) %>%
  head(1)

max
min
sr=min+(max-min)/2
sr=sr$lat
sr

#poludnie

poludnie=df %>%
  filter(lat<sr) %>% 
  select(price)
poludnie=poludnie$price
poludnie
pom=unname(quantile(poludnie, prob=c(0.25, 0.75)))
pom[2]-pom[1]

#polnoc

polnoc=df %>%
  filter(lat>sr) %>% 
  select(price)
polnoc=polnoc$price
polnoc
pom2=unname(quantile(polnoc, prob=c(0.25, 0.75)))
pom2
pom2[2]-pom2[1]

# Odp: Odst�p mi�dzykwartylowy ceny mieszka� po�o�onych na p�nocy wynosi 321000 USD a tych na po�udniu 122500 USD

# 7. Jaka liczba �azienek wyst�puje najcz�ciej i najrzadziej w nieruchomo�ciach niepo�o�onych nad wod�, kt�rych powierzchnia wewn�trzna na kondygnacj� nie przekracza 1800 sqft?
bathdane=df %>% 
  filter(waterfront == 0) %>% 
  mutate(pow_na_kon=sqft_living/floors) %>% 
  filter(pow_na_kon<=1800) %>% 
  group_by(bathrooms) %>% 
  summarise(n=n()) %>% 
  arrange(n)

#najrzadziej
head(bathdane, 1)

#najczesciej
bathdane %>% 
  arrange(-n) %>% 
  head(1)

# Odp: Najcz�iej wyst�puje 2.5 �azienek a najrzadziej 4.75 �azienek

# 8. Znajd� kody pocztowe, w kt�rych znajduje si� ponad 550 nieruchomo�ci. Dla ka�dego z nich podaj odchylenie standardowe powierzchni dzia�ki oraz najpopularniejsz� liczb� �azienek
kody=df %>% 
  group_by(zipcode) %>% 
  summarise(n=n()) %>% 
  filter(n>550)
kody=kody$zipcode
kody

df %>% 
  filter(zipcode %in% kody) %>% 
  group_by(zipcode) %>% 
  summarise(od_stan_pow=sd(sqft_lot))


df %>% 
  filter(zipcode %in% kody) %>% 
  group_by(zipcode, bathrooms) %>% 
  summarise(l_laz=n()) %>% 
  top_n(1, l_laz)
  
# Odp: Odchylenia standardowe dla kolejnych zipcode [98038, 98052, 98103, 98115, 98117] to [63111, 10276, 1832, 2675, 2319];
       #Najpopularniejsze liczby �azienek to kolejno [2.5, 2.5, 1, 1, 1]

# 9. Por�wnaj �redni� oraz median� ceny nieruchomo�ci, kt�rych powierzchnia mieszkalna znajduje si� w przedzia�ach (0, 2000], (2000,4000] oraz (4000, +Inf) sqft, nieznajduj�cych si� przy wodzie.
df_nie_woda=df %>% 
  filter(waterfront == 0)

#0-2000
df_nie_woda %>% 
  filter(sqft_living<=2000) %>% 
  summarise(median(price),
            mean(price))

#2000-4000
df_nie_woda %>% 
  filter(sqft_living>2000 & sqft_living<=4000) %>% 
  summarise(median(price),
            mean(price))

#4000+

df_nie_woda %>% 
  filter(sqft_living>4000) %>% 
  summarise(median(price),
            mean(price))
  

# Odp: W ka�dym z przedzia��w �rednia jest wy�sza od mediany. Ceny �rednie i mediany rosn� wraz ze wzrostem powierzchni mieszkalnej.
#�rednie i mediany dla przedzia��w (0, 2000], (2000, 4000], (4000, Inf) wynosz� kolejno (w USD) [359000, 385084.3], [595000, 645419], [1262750, 1448119].

# 10. Jaka jest najmniejsza cena za metr kwadratowy nieruchomo�ci? (bierzemy pod uwag� tylko powierzchni� wewn�trz mieszkania)
#metr kwadratowy jest w przybli�eniu r�wny 10.76 stopom kwadratowym
df %>% 
  mutate(cena_za_metr_2=price/(sqft_living/10.76)) %>% 
  select(cena_za_metr_2) %>% 
  arrange(cena_za_metr_2) %>% 
  head(1)

# Odp: 942.4494 USD

