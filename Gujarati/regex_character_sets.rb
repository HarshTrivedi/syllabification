# Regex Character Sets
# (For easy searching regex searching in Gujarati)

# 1. Matras
$guj_matra_regex = Regexp.new(/[ાિીુૂૅૅૈોૉૌં્]/)

# 2. Vowel
$guj_vowel_regex = Regexp.new(/[અઆઇઈઉઊએઍઐઓઑઔ]/)

# 3. Consonants
$guj_consonant_regex = Regexp.new(/[કખગઘઙચછજઝઞટઠડઢણતથદધનપફબમયરલવશષસહળ]/)

# 4. All Gujarati Characters
$guj_all_regex = Regexp.new(/[કખગઘઙચછજઝઞટઠડઢણતથદધનપફબમયરલવશષસહળઅઆઇઈઉઊએઍઐઓઑઔાિીુૂૅૅૈોૉૌં્]/)