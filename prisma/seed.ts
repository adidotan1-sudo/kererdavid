import { PrismaClient } from "@prisma/client";
import { hashPin } from "../lib/session";

const db = new PrismaClient();

const DEFAULT_PIN = "5555";

async function main() {
  await db.session.deleteMany();
  await db.appointment.deleteMany();
  await db.historyEntry.deleteMany();
  await db.punchCard.deleteMany();
  await db.client.deleteMany();
  await db.providerAuth.deleteMany();

  const { hash, salt } = hashPin(DEFAULT_PIN);
  await db.providerAuth.create({ data: { id: 1, pinHash: hash, pinSalt: salt } });

  const sarah = await db.client.create({
    data: {
      name: "שרה לוי",
      phone: "0521234567",
      card: { create: { total: 10, used: 10 } },
      history: {
        create: [
          { service: "הסרת עין הרע", date: new Date("2026-05-03") },
          { service: "הסרת עין הרע", date: new Date("2026-05-17") },
          { service: "איזון אנרגטי", date: new Date("2026-06-01") },
          { service: "הסרת עין הרע", date: new Date("2026-06-14") },
          { service: "טיהור הבית / העסק", date: new Date("2026-06-28") },
          { service: "הסרת עין הרע", date: new Date("2026-07-05") },
          { service: "הסרת עין הרע", date: new Date("2026-07-12") },
          { service: "איזון אנרגטי", date: new Date("2026-07-19") },
          { service: "הסרת עין הרע", date: new Date("2026-07-26") },
          { service: "הסרת עין הרע", date: new Date("2026-08-02") },
        ],
      },
      appointments: {
        create: [
          {
            serviceId: "ayin",
            serviceTitle: "הסרת עין הרע",
            phone: "0521234567",
            notes: "מרגישה עייפות מוזרה ומזל רע שבוע האחרון.",
            requestedDate: "2026-08-10",
            status: "new",
            kind: "booking",
          },
        ],
      },
    },
  });

  const yossi = await db.client.create({
    data: {
      name: "יוסי אברהם",
      phone: "0537654321",
      card: { create: { total: 10, used: 6 } },
      history: {
        create: [
          { service: "טיהור הבית / העסק", date: new Date("2026-06-02") },
          { service: "טיהור הבית / העסק", date: new Date("2026-06-16") },
          { service: "הסרת חסמות ותיקונים", date: new Date("2026-06-30") },
          { service: "טיהור הבית / העסק", date: new Date("2026-07-14") },
          { service: "איזון אנרגטי", date: new Date("2026-07-28") },
          { service: "טיהור הבית / העסק", date: new Date("2026-08-04") },
        ],
      },
      appointments: {
        create: [
          {
            serviceId: "home",
            serviceTitle: "טיהור הבית / העסק",
            phone: "0537654321",
            notes: "עברנו דירה חדשה ומרגישים תחושה כבדה בבית.",
            requestedDate: "2026-08-09",
            status: "scheduled",
            kind: "booking",
          },
        ],
      },
    },
  });

  const ronit = await db.client.create({
    data: {
      name: "רונית ברק",
      phone: "0541122334",
      card: { create: { total: 5, used: 2 } },
      history: {
        create: [
          { service: "איזון אנרגטי", date: new Date("2026-07-10") },
          { service: "איזון אנרגטי", date: new Date("2026-07-24") },
        ],
      },
      appointments: {
        create: [
          {
            serviceId: "balance",
            serviceTitle: "איזון אנרגטי",
            phone: "0541122334",
            notes: "חוסר ריכוז ותחושת כובד מתמשכת כבר חודש.",
            requestedDate: "2026-08-03",
            status: "done",
            kind: "booking",
          },
        ],
      },
    },
  });

  const michal = await db.client.create({
    data: {
      name: "מיכל כהן",
      phone: "0529365970",
      card: { create: { total: 10, used: 4 } },
      history: {
        create: [
          { service: "הסרת כישופים", date: new Date("2026-06-20") },
          { service: "הסרת כישופים", date: new Date("2026-07-01") },
          { service: "טיפול בחרדות", date: new Date("2026-07-15") },
          { service: "הסרת כישופים", date: new Date("2026-07-29") },
        ],
      },
    },
  });

  console.log("Seeded clients:", [sarah.name, yossi.name, ronit.name, michal.name]);
  console.log("David's PIN:", DEFAULT_PIN);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => db.$disconnect());
