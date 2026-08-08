"use server";

import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { createProviderSession, hashPin, requireProvider, verifyPin } from "@/lib/session";

export async function providerLogin(formData: FormData) {
  const pin = String(formData.get("pin") || "").trim();
  const auth = await db.providerAuth.findUnique({ where: { id: 1 } });
  if (!auth || !verifyPin(pin, auth.pinHash, auth.pinSalt)) {
    redirect("/david/login?error=1");
  }
  await createProviderSession();
  redirect("/david");
}

export async function setRequestStatus(formData: FormData) {
  await requireProvider();
  const id = String(formData.get("id") || "");
  const status = String(formData.get("status") || "");
  if (!["new", "scheduled", "done"].includes(status)) redirect(`/david/requests/${id}`);

  const appt = await db.appointment.update({ where: { id }, data: { status } });

  if (status === "done" && appt.kind === "booking" && appt.serviceTitle) {
    await db.historyEntry.create({
      data: {
        clientId: appt.clientId,
        service: appt.serviceTitle,
        date: appt.requestedDate ? new Date(appt.requestedDate) : new Date(),
      },
    });
  }
  redirect(`/david/requests/${id}`);
}

// Punches the client's card and closes out a card-linked request (card_new,
// card_renewal, card_treatment) in one action, so the punch always happens
// together with completion instead of relying on David to remember a
// separate manual adjustment on the client's card screen.
export async function punchRequest(formData: FormData) {
  await requireProvider();
  const id = String(formData.get("id") || "");
  const appt = await db.appointment.findUnique({ where: { id } });
  if (!appt) redirect("/david");

  await db.appointment.update({ where: { id }, data: { status: "done" } });

  const card = await db.punchCard.findUnique({ where: { clientId: appt.clientId } });
  if (card) {
    if (appt.kind === "card_new" || appt.kind === "card_renewal") {
      await db.punchCard.update({
        where: { clientId: appt.clientId },
        data: { used: 1, renewalRequested: false },
      });
    } else if (appt.kind === "card_treatment") {
      await db.punchCard.update({
        where: { clientId: appt.clientId },
        data: { used: Math.min(card.total, card.used + 1) },
      });
    }
  }

  if (appt.kind === "card_treatment" && appt.serviceTitle) {
    await db.historyEntry.create({
      data: {
        clientId: appt.clientId,
        service: appt.serviceTitle,
        date: appt.requestedDate ? new Date(appt.requestedDate) : new Date(),
      },
    });
  }

  redirect(`/david/requests/${id}`);
}

export async function adjustCardUsed(formData: FormData) {
  await requireProvider();
  const clientId = String(formData.get("clientId") || "");
  const delta = Number(formData.get("delta") || 0);
  const card = await db.punchCard.findUnique({ where: { clientId } });
  if (!card) redirect(`/david/clients/${clientId}`);

  const used = Math.max(0, Math.min(card.total, card.used + delta));
  await db.punchCard.update({ where: { clientId }, data: { used } });
  redirect(`/david/clients/${clientId}`);
}

export async function changePin(formData: FormData) {
  await requireProvider();
  const current = String(formData.get("current") || "").trim();
  const next = String(formData.get("next") || "").trim();
  const confirm = String(formData.get("confirm") || "").trim();

  const auth = await db.providerAuth.findUnique({ where: { id: 1 } });
  if (!auth || !verifyPin(current, auth.pinHash, auth.pinSalt)) {
    redirect("/david/settings?error=wrong");
  }
  if (next.length < 4 || next !== confirm) {
    redirect("/david/settings?error=invalid");
  }

  const { hash, salt } = hashPin(next);
  await db.providerAuth.update({ where: { id: 1 }, data: { pinHash: hash, pinSalt: salt } });
  redirect("/david/settings?saved=1");
}
