module.exports = {
  model: model
};

async function model() {
  return await db.call('SELECT * FROM MUSAB_ROUTES');
}
