import { connectToDatabase } from '../../../src/mongo'
import bcrypt from 'bcryptjs'

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end()
  const { name, email, password, role = 'contractor', description = '' } = req.body || {}
  if (!email || !password) return res.status(400).json({ error: 'email and password required' })
  try {
    const { db } = await connectToDatabase()
    const users = db.collection('users')
    const existing = await users.findOne({ email })
    if (existing) return res.status(409).json({ error: 'user exists' })
    const hashed = await bcrypt.hash(password, 10)
    const now = new Date()
    const r = await users.insertOne({ name, email, password: hashed, role, description, createdAt: now })
    return res.status(201).json({ id: r.insertedId.toString(), email, name, role })
  } catch (e) {
    console.error(e)
    return res.status(500).json({ error: e.message })
  }
}
