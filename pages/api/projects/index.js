import { connectToDatabase } from '../../../src/mongo'

export default async function handler(req, res) {
  try {
    const { db } = await connectToDatabase()
    const projects = db.collection('projects')
    if (req.method === 'GET') {
      const docs = await projects.find({}).sort({ createdAt: -1 }).limit(200).toArray()
      return res.status(200).json(docs.map(d => ({ id: d._id.toString(), ...d })))
    }
    if (req.method === 'POST') {
      const { type, location, minBudget, maxBudget, description, clientId } = req.body || {}
      const now = new Date()
      const r = await projects.insertOne({ type, location, minBudget, maxBudget, description, clientId, status: 'Pending', createdAt: now })
      return res.status(201).json({ id: r.insertedId.toString() })
    }
    return res.status(405).end()
  } catch (e) {
    console.error(e)
    return res.status(500).json({ error: e.message })
  }
}
