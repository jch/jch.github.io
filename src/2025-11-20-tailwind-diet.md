# Reducing Tailwind asset size

I consolidated the form and typography styling I was using across [jch.app](https://jch.app)
and reduced the stylesheet bundle size 56% from 156kb to 68k. There's more room to trim
from the default reset and utility classes, but this felt like a good stopping place.

```
$ find public -name '*.css' | xargs du -sh | sort -n

# Baseline 2058e695fa2cac93a48520e85f6ae6d4f2846345
4.0K	public/assets/application.tailwind-2569b4b8.css
156K	public/assets/tailwind-1836982c.css

# After removing @tailwindcss/forms 513a0b726ab6a99ea5d5c59a4fc41178546d214d
8.0K	public/assets/application.tailwind-18ab7e13.css
 88K	public/assets/tailwind-44187fa0.css

# After removing @tailwindcss/typography
8.0K  public/assets/application.tailwind-89bca1fa.css
 68K  public/assets/tailwind-59d86ce3.css
```
