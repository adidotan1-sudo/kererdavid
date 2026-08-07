# הרצה ופריסה — כתר דויד

## הרצה מקומית

```
npm install
cp .env.example .env   # ומעדכנים את DATABASE_URL להתחבר ל-Postgres מקומי/מרוחק
npx prisma migrate dev
npx prisma db seed
npm run dev
```

קוד הגישה הראשוני של דויד: `5555` (ניתן להחלפה במסך "הגדרות" בתוך האפליקציה).

## פריסה לאוויר

**1. Postgres בענן (Neon, חינמי, בלי כרטיס אשראי)**
1. neon.tech → הרשמה (אפשר עם GitHub)
2. Create a project
3. להעתיק את ה-Connection string מהדשבורד

**2. GitHub**
1. github.com/new → ליצור ריפו ריק (בלי README, כדי לא להתנגש עם ההיסטוריה הקיימת)
2. `git remote add origin <repo-url>`
3. `git push -u origin main`

**3. Vercel**
1. vercel.com → הרשמה עם GitHub → Import Project → לבחור את הריפו
2. Environment Variables → להוסיף `DATABASE_URL` עם ה-connection string מ-Neon
3. Deploy — סקריפט ה-build (`prisma migrate deploy && next build`) יריץ את המיגרציות אוטומטית על כל דיפלוי

**4. אחרי הפריסה**
- לגלוש ל-`/david/login`, להיכנס עם `5555`, ומיד להחליף קוד במסך "הגדרות"
- לשלוח ללקוחות את קישור האתר (כמו קישור הוואטסאפ שדויד שולח בעיצוב המקורי)
