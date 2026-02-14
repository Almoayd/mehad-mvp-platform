import { connectToDatabase } from '../../../../src/mongo'
import { ObjectId } from 'mongodb'

export default async function handler(req, res) {
  const { id } = req.query || {}
  if (!id) return res.status(400).json({ error: 'missing project id' })
  try {
    const { db } = await connectToDatabase()
    const messages = db.collection('messages')
    if (req.method === 'GET') {
      const docs = await messages.find({ projectId: id }).sort({ createdAt: 1 }).toArray()
      return res.status(200).json(docs.map(d => ({ id: d._id.toString(), ...d })))
    }
    if (req.method === 'POST') {
      const { text, sender } = req.body || {}
      const now = new Date()
      const r = await messages.insertOne({ projectId: id, text, sender, createdAt: now })
      return res.status(201).json({ id: r.insertedId.toString() })
    }
    return res.status(405).end()
  } catch (e) {
    console.error(e)
    return res.status(500).json({ error: e.message })
  }
}
