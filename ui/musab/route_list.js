module.exports.model = async () => {
  return await db.call('SELECT * FROM MUSAB_ROUTE');
}
