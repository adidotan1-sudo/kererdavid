"use server";

import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { createClientSession, requireClient } from "@/lib/session";
import { findService } from "@/lib/services";

export async function registerClient(formData: FormData) {
  const name = String(formData.get("name") || "").trim();
  const phone = String(formData.get("phone") || "").trim();
  if (!name || !phone) redirect("/");

  let client = await db.client.findUnique({ where: { phone } });
  if (!client) {
    client = await db.client.create({
      data: { name, phone, card: { create: { total: 10, used: 0 } } },
    });
  } else {
    client = await db.client.update({ where: { id: client.id }, data: { name } });
    const card = await db.punchCard.findUnique({ where: { clientId: client.id } });
    if (!card) await db.punchCard.create({ data: { clientId: client.id, total: 10, used: 0 } });
  }
  await createClientSession(client.id);
  redirect("/app");
}

export async function updateMyDetails(formData: FormData) {
  const client = await requireClient();
  const name = String(formData.get("name") || "").trim();
  const phone = String(formData.get("phone") || "").trim();
  if (name && phone) {
    try {
      await db.client.update({ where: { id: client.id }, data: { name, phone } });
    } catch {
      // phone already taken by another client — keep previous values
    }
  }
  redirect("/app/my");
}

export async function submitBooking(formData: FormData) {
  const client = await requireClient();
  const serviceId = String(formData.get("serviceId") || "");
  const service = findService(serviceId);
  const name = String(formData.get("name") || "").trim() || client.name;
  const phone = String(formData.get("phone") || "").trim() || client.phone;
  const date = String(formData.get("date") || "");
  const notes = String(formData.get("notes") || "").trim() || "—";

  await db.client.update({ where: { id: client.id }, data: { name, phone } });
  await db.appointment.create({
    data: {
      clientId: client.id,
      serviceId: service?.id,
      serviceTitle: service?.title || "",
      phone,
      notes,
      requestedDate: date || null,
      status: "new",
      kind: "booking",
    },
  });
  redirect("/app/confirmed");
}

export async function requestCard(_formData: FormData) {
  const client = await requireClient();
  const card = await db.punchCard.findUnique({ where: { clientId: client.id } });
  if (!card || card.renewalRequested) redirect("/app/my");

  const isFirst = card.used === 0;
  await db.punchCard.update({ where: { clientId: client.id }, data: { renewalRequested: true } });
  await db.appointment.create({
    data: {
      clientId: client.id,
      serviceTitle: isFirst ? "בקשת כרטיסיית טיפולים" : "חידוש כרטיסיית טיפולים",
      phone: client.phone,
      notes: isFirst ? "בקשה לפתיחת כרטיסיית 10 טיפולים." : "בקשה לחידוש כרטיסיית 10 טיפולים.",
      status: "new",
      kind: isFirst ? "card_new" : "card_renewal",
    },
  });
  redirect("/app/my");
}

export async function editAppointment(formData: FormData) {
  const client = await requireClient();
  const id = String(formData.get("id") || "");
  const date = String(formData.get("date") || "");
  const notes = String(formData.get("notes") || "").trim();

  const appt = await db.appointment.findUnique({ where: { id } });
  if (!appt || appt.clientId !== client.id) redirect("/app/my");

  await db.appointment.update({
    where: { id },
    data: { requestedDate: date || null, notes: notes || appt.notes },
  });
  redirect("/app/my");
}
