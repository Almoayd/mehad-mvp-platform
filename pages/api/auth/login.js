import { connectToDatabase } from '../../../src/mongo'
import bcrypt from 'bcryptjs'

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end()
  const { email, password } = req.body || {}
  if (!email || !password) return res.status(400).json({ error: 'email and password required' })
  try {
    const { db } = await connectToDatabase()
    const users = db.collection('users')
    const u = await users.findOne({ email })
    if (!u) return res.status(404).json({ error: 'user not found' })
    const ok = await bcrypt.compare(password, u.password || '')
    if (!ok) return res.status(401).json({ error: 'invalid credentials' })
    // return basic profile (no password)
    const { password: _p, ...safe } = u
    safe.id = safe._id.toString()
    delete safe._id
    return res.status(200).json({ user: safe })
  } catch (e) {
    console.error(e)
    return res.status(500).json({ error: e.message })
  }
}
