
interface TaskItem {
  uid: string;
  title: string;
  posix: number;
}

async function postItem(title: string) : Promise<TaskItem> {
  const dt = Date.now()
  return {
    uid: dt.toString(),
    title: title,
    posix: dt,
  }
}

export { postItem }
