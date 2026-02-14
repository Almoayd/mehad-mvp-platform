require('dotenv').config({ path: '.env.local' })
const { MongoClient, ObjectId } = require('mongodb')

const uri = process.env.MONGODB_URI || ''
const dbName = process.env.MONGODB_DB || 'mehad'

if (!uri) {
  console.error('MONGODB_URI is not set. Set it and re-run: MONGODB_URI=... node scripts/seed.js')
  process.exit(1)
}

async function run(){
  const client = new MongoClient(uri)
  try{
    await client.connect()
    const db = client.db(dbName)

    const users = db.collection('users')
    const projects = db.collection('projects')
    const messages = db.collection('messages')

    // Create sample users if not exists
    const alice = await users.findOne({ email: 'alice@example.com' })
    if (!alice) {
      const r = await users.insertOne({ name: 'Alice Client', email: 'alice@example.com', password: 'seed-password', role: 'client', description: 'Client who posts projects', createdAt: new Date() })
      console.log('Inserted user alice id=', r.insertedId.toString())
    }
    const bob = await users.findOne({ email: 'bob@example.com' })
    if (!bob) {
      const r = await users.insertOne({ name: 'Bob Contractor', email: 'bob@example.com', password: 'seed-password', role: 'contractor', description: 'Skilled contractor', createdAt: new Date() })
      console.log('Inserted user bob id=', r.insertedId.toString())
    }

    // Create sample project
    const p = await projects.findOne({ title: 'Build landing page' })
    let projectId
    if (!p) {
      const r = await projects.insertOne({ title: 'Build landing page', type: 'web', location: 'Remote', minBudget: 100, maxBudget: 500, description: 'Need a simple responsive landing page', clientEmail: 'alice@example.com', status: 'Open', createdAt: new Date() })
      projectId = r.insertedId.toString()
      console.log('Inserted project id=', projectId)
    } else {
      projectId = p._id.toString()
      console.log('Project already exists id=', projectId)
    }

    // Create sample messages
    const existingMsgs = await messages.findOne({ projectId })
    if (!existingMsgs) {
      const now = new Date()
      await messages.insertMany([
        { projectId, text: 'Hi, I can help with this.', sender: 'bob@example.com', createdAt: now },
        { projectId, text: 'Great — please share your portfolio.', sender: 'alice@example.com', createdAt: new Date(now.getTime()+1000) }
      ])
      console.log('Inserted sample messages for project', projectId)
    } else {
      console.log('Messages already exist for project', projectId)
    }

    console.log('Seeding complete')
  }catch(e){
    console.error('Seed error', e)
  }finally{
    await client.close()
  }
}

run()
