# Regex Character Sets
# (For easy searching regex searching in Gujarati)

# 1. Matras
$guj_matra_regex = Regexp.new(/[ાિીુૂૅેૈોૉૌૃૄ્ઁંઃ઼ઽ]/)

# 2. Vowel
$guj_vowel_regex = Regexp.new(/[અઆઇઈઉઊએઍઐઓઑઔ]/)

# 3. Consonants
$guj_consonant_regex = Regexp.new(/[કખગઘઙચછજઝઞટઠડઢણતથદધનપફબભમયરલવશષસહળ]/)

# 4. All Gujarati Characters
$guj_all_regex = Regexp.new(/[કખગઘઙચછજઝઞટઠડઢણતથદધનપફબભમયરલવશષસહળઅઆઇઈઉઊએઍઐઓઑઔાિીુૂૅેૈોૉૌૃૄ્ઁંઃ઼ઽ]/)

# 5. Non Gujaratic alphabets (gujarati numbers excluded)
$non_guj_regex = Regexp.new(/[^કખગઘઙચછજઝઞટઠડઢણતથદધનપફબભમયરલવશષસહળઅઆઇઈઉઊએઍઐઓઑઔાિીુૂૅેૈોૉૌૃૄ્ઁંઃ઼ઽ]/)
